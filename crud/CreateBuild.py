import pytz

from sqlalchemy.orm import Session

import models
import schemas


def create_module_build(db: Session, build: schemas.ModuleBuild):
    print(build)
    db_build = models.ModuleBuild(
        module=build.module,
        build_time=build.build_time,
        result=build.result,
        finished_at=build.finished_at.astimezone(pytz.utc),
        maven_opts=build.maven_opts,
        uname=build.uname,
        uuid=str(build.uuid),
        cpu=build.cpu,
        mem=build.mem,
    )
    db.add(db_build)
    db.flush()
    return db_build
