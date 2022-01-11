from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session

from database import Base, SessionLocal, engine
import models  # noqa: F401
import schemas
from crud import create_module_build, create_submodule_builds

Base.metadata.create_all(bind=engine)

app = FastAPI()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.post("/build", response_model=schemas.ModuleBuildResponse)
def get_body(build: schemas.ModuleBuild, db: Session = Depends(get_db)):
    db_build = create_module_build(db=db, build=build)
    create_submodule_builds(db=db, submodule_builds=build.submodules, build_id=db_build.id)
    db.commit()
    return db_build
