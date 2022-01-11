from pydantic import BaseModel

from .BuildStatus import BuildStatus


class SubModuleBuild(BaseModel):
    module: str
    build_time: str
    result: BuildStatus

    class Config:
        orm_mode = True


class SubModuleBuildResponse(BaseModel):
    id: int
    module: str
    # build_time: str
    # result: BuildStatus

    class Config:
        orm_mode = True
