#!/usr/bin/env python3
# Turns FNA.csproj into an mcs response file. FNA 22.03 has no build that
# targets Mono's compiler directly, but the csproj carries everything needed:
# the source list and the embedded effect resources. Run from the FNA clone.
import re

xml = open("FNA.csproj").read()
args = ["-target:library", "-out:bin/Release/FNA.dll", "-unsafe+", "-optimize+",
        "-sdk:4.5", "-r:System.dll", "-nowarn:0414,0219,0169,0649,0067,1635"]
for res, name in re.findall(
        r'<EmbeddedResource Include="([^"]+)">\s*<LogicalName>([^<]+)</LogicalName>', xml):
    args.append("-resource:{0},{1}".format(res.replace("\\", "/"), name))
args += [s.replace("\\", "/") for s in re.findall(r'<Compile Include="([^"]+)"', xml)]
open("build.rsp", "w").write("\n".join(args) + "\n")
