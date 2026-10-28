from __future__ import annotations

import sys
from functools import cache
from io import BytesIO
from typing import TYPE_CHECKING, Dict, Optional, cast

from tpk_ar import TpkFile, TpkTypeTreeBlob, TpkUnityClass, TpkUnityNode
from tpk_ar import UnityVersion as TpkUnityVersion

from . import TypeTreeHelper
from .UnityVersion import UnityVersion

if TYPE_CHECKING:
    from .TypeTreeHelper import TypeTreeNode


@cache
def get_typetree() -> TpkTypeTreeBlob:
    package = "UnityPy.resources"
    resource = "lzma.tpk"

    tpk_data: bytes
    if sys.version_info >= (3, 9):
        from importlib.resources import files

        tpk_data = files(package).joinpath(resource).read_bytes()

    else:
        from importlib.resources import open_binary

        tpk_data = open_binary(package, resource).read()

    with BytesIO(tpk_data) as stream:
        tree = TpkFile.parse(stream).GetDataBlob()
    assert isinstance(tree, TpkTypeTreeBlob)
    return tree


@cache
def get_typetree_node(class_id: int, version: UnityVersion):
    tpk_version = cast(TpkUnityVersion, version)
    class_info = get_typetree().ClassInformation[class_id].getVersionedClass(tpk_version)
    if class_info is None:
        raise ValueError("Could not find class info for class id {}".format(class_id))

    node = generate_node(class_info)
    return node


@cache
def generate_node(class_info: TpkUnityClass) -> "TypeTreeNode":
    assert class_info.ReleaseRootNode is not None, "Class {} has no ReleaseRootNode".format(class_info)

    TypeTreeNode = TypeTreeHelper.TypeTreeNode

    nodes = []
    NODES = get_typetree().NodeBuffer
    STRINGBUFFER = get_typetree().StringBuffer
    stack = [(class_info.ReleaseRootNode, 0)]
    index = 0
    while stack:
        node_id, level = stack.pop(0)
        node: TpkUnityNode = NODES[node_id]
        nodes.append(
            TypeTreeNode(
                m_ByteSize=node.ByteSize,
                m_Index=index,
                m_Version=node.Version,
                m_MetaFlag=node.MetaFlag,
                m_Level=level,
                m_Type=STRINGBUFFER[node.TypeName],
                m_Name=STRINGBUFFER[node.Name],
            )
        )
        stack = [(node_id, level + 1) for node_id in node.SubNodes] + stack
        index += 1
    return TypeTreeNode.from_list(nodes)


@cache
def get_common_strings(version: Optional[UnityVersion] = None) -> Dict[int, str]:
    tpk_version: TpkUnityVersion | None = cast(TpkUnityVersion, version) if version is not None else None
    return get_typetree().CommonString.BuildMap(get_typetree().StringBuffer, tpk_version)
