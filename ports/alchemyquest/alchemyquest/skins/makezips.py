import os, zipfile

# FUNCTION TO MAKE ZIP 
def zipFile(dir):
        oldpath = os.getcwd()
        f = zipfile.ZipFile(dir+'.zip','w',zipfile.ZIP_DEFLATED)
        os.chdir(dir)
        for root, dirs, files in os.walk('.'):
                if '.sconsign' in files:
                        files.remove('.sconsign')
                
                for afile in files:
                        rroot = root[2:]
                        if not rroot:
                                f.write(afile)
                        else:
                                #print root[2:]+"/"+afile
                                aafile = root[2:]+"/"+afile
                                f.write(aafile)
                
                if '.svn' in dirs:
                        dirs.remove('.svn')  # don't visit SVN directories
        f.close()
        os.chdir(oldpath)
        print dir+" zip created"
         
zipFile("aqua")
zipFile("brushed")
zipFile("vectoriel")
 