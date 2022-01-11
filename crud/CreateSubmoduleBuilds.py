from sqlalchemy.orm import Session

import models
import schemas


def db_add(db, submodule, build_id):
    db.add(models.SubModuleBuild(
        module=submodule.module,
        build_time=submodule.build_time,
        result=submodule.result,
        module_build_id=build_id
    ))


def create_submodule_builds(db: Session, submodule_builds: schemas.SubModuleBuild, build_id: int):
    return list(map(
        lambda submodule: db_add(db, submodule, build_id), submodule_builds
    ))
