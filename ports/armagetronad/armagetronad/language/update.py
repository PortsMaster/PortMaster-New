#!/usr/bin/python2
# usage: call here to bring all translations up to date
# usage forms:
# update.py [--complete] <list of language files>
#           updates all language files in the editable form (with comments); untranslated items
#           are marked and decorated with the original text and the translations from the other
#           languages from the given file list. Example:
#           update.py spanish.txt is useful for editing the portugese translation if the s
#           panish translation is up to date.
#           the --complete switch adds the original texts as comments to all items, even
#           those already translated.
#           the --scm switch removes all comments added by previous runs so you can
#           easily check in partial translations into source control.
#
# update.py --dist
#           compactifies translations: strips comments and whitespace

from __future__ import print_function

import sys
import os
import string

def OpenFile( filename, mode ):
    if sys.version_info[0] > 2:
        return open(filename, mode, encoding = "latin1" )
    else:
        return open(filename, mode )
        
# parse line for identifier/value pattern
class LanguageUpdater:
    def __init__(self):
        # maximal assumed length of identifier
        self.maxlen = 30
        self.commentAll  = False
        self.commentNone = False
        self.autoComment = "#ORIGINAL TEXT:"
        self.autoComment2 = "#TRANSLATION "
        self.untranslated = "UNTRANSLATED\n"
        self.outdated = "# Outdated:\n"
        
        self.translations = {}

    def ParseLine( self, line ):
        stripped = line.expandtabs(4).lstrip()
        if len(stripped) > 0 and stripped[0] != '#':
            pair = stripped.split(" ",1)
            pair[1] = pair[1].lstrip()
            return pair
        else:
            return False
    
    def Write( self, key, value ):
        self.outfile.write( (key + " ").ljust( self.maxlen ) + value )

    # fetch, print and delete translation from dictionary
    def WriteFromDictionary( self, key ):
        try:
            # fetch translation...
            trans = self.dictionary[ key ]
            # print it...
            self.Write( key, trans )
            # and delete it.
            del self.dictionary[ key ]
        except KeyError:
            # translation not found: note that.
            if not self.commentNone:
                self.Write( "#" + key, self.untranslated )

    # writes dictionary to open outfile
    def WriteDictionary0( self ):
        for key in self.dictionary:
            self.Write( key, self.dictionary[key] )

    # opens file, writes dictionary
    def WriteDictionary1( self, translation ):
        # open outfile
        self.outfile = OpenFile( translation, "w" ) 

        # write to it in condensed form
        self.WriteHeader()
        self.outfile.write("# We don't maintain this file in this horrible unsorted format.\n# Execute update.py without arguments to return it into its good form.\n\n")
        self.WriteDictionary0()

        # close outfile
        self.outfile.close()
        del self.outfile

    def WriteHeader( self ):
        # write language the outfile is in
        self.outfile.write(self.leadingComment)
        self.WriteFromDictionary( "language" )
        self.outfile.write("\n")

    # read contents of translation into dictionary
    def ReadDictionary( self, translation ):
        # read translation into dictionary
        self.leadingComment = ""
        started = False
        outfilein = OpenFile( translation, "r" )
        self.dictionary = {}
        self.lostcomments = {}
        for line in outfilein.readlines():
            # parse line for identifier/value pattern
                pair = self.ParseLine( line )
                # put pair into dictionary
                if pair != False:
                    started = True
                    self.dictionary[pair[0]] = pair[1]
                else:
                    if not started:
                        self.leadingComment += line;
                    else:
                        if not line.startswith( self.autoComment ) and not line.startswith( self.autoComment2 ) and not line.endswith( self.untranslated ) and not line == self.outdated:
                            self.lostcomments[line] = True
        outfilein.close()

    # write contents of dictionary in the order its items appear in the file base.
    def WriteDictionary( self, base, translation ):
        # open outfile
        self.outfile = OpenFile( translation, "w" )
        
        # open infile
        infile  = OpenFile( base, "r" )
    
        self.WriteHeader()

        # flag indicating whether the next item needs an extra separation line
        separate = True    

        # flag indicating whether the last language item was translated
        lastTranslated = True

        # flag indicating whether the last line was empty
        lastEmpty = False

        # read through base file, rewriting it
        for line in infile.readlines():
            pair = self.ParseLine( line )
            if pair == False:
                # delete comment from lost comment archive
                try: del self.lostcomments[ line ]
                except KeyError: pass
                # just print line, it is a comment or whitespace
                empty = ( len(line) <= 1 )
                if lastTranslated or ( not empty or not lastEmpty ):
                    self.outfile.write( line )
                    lastEmpty = empty
                separate = False
            else:
                if not pair[0] == "include":
                    # write original text as a comment
                    lastTranslated = pair[0] in self.dictionary
                    if self.commentAll or ( not lastTranslated and not self.commentNone ):
                        if separate:
                            self.outfile.write("\n")
                        self.Write( self.autoComment, pair[1] )
                        for otherTranslation in self.translations:
                            try:
                                self.Write( self.autoComment2 + otherTranslation, self.translations[otherTranslation][pair[0]] )
                            except KeyError: pass
                       
                    # write translation
                    self.WriteFromDictionary( pair[0] )
                    separate = True
                
        # write translated items that don't appear in the original
        if len( self.dictionary ) > 0:
            self.outfile.write( "\n" + self.outdated )
            self.WriteDictionary0()

        # write old comments
        for line in self.lostcomments:
            self.outfile.write( line )
        
        self.outfile.close()
        del self.outfile
    
    # update translation files with new items to translate
    def Translate( self, base, translation ):
        # read dictionary
        self.ReadDictionary( translation )
        # rewrite into different file
        self.WriteDictionary( base, translation + ".out" )

        # rename files if no error happened
        os.rename( translation, translation + ".bak" )
        os.rename( translation + ".out", translation )

    # update translation files for distribution
    def Distribute( self, translation ):
        # read dictionary
        self.ReadDictionary( translation )
        # rewrite into different file
        self.WriteDictionary1( translation + ".out" )

        # rename files if no error happened
        os.rename( translation, translation + ".bak" )
        os.rename( translation + ".out", translation )

    # add a file to the list of translations to print along with the english original
    def AddTranslation( self, file ):
        # read dictionary
        self.ReadDictionary( file )
        # store it
        self.translations[string.split(file,".")[0]] = self.dictionary
        del self.dictionary

if __name__ == "__main__":
    # determine languages to update: everything included from
    # languages.txt.in except am/eng and custom.
    files = []
    listfile = OpenFile( "languages.txt.in", "r" )
    for line in listfile.readlines():
        if line.startswith("include"):
            file =line.split()[1]
            if file != "american.txt" and file != "english.txt" and file != "british.txt" and file != "custom.txt":
                files += [file]

    lu = LanguageUpdater()
    if len( sys.argv ) >= 2 and sys.argv[1] == "--dist":
        # strip comments from translations
        lu.maxlen = 0
        for file in files:            
            lu.Distribute( file );
    else:
        if len( sys.argv ) >= 2 and sys.argv[1] == "--complete":
            lu.commentAll = True
        if len( sys.argv ) >= 2 and sys.argv[1] == "--scm":
            lu.commentNone = True

        # read in all translations
        for file in sys.argv[1:]:
            if file[0] != "-":
                lu.AddTranslation(file);
            
        # update translations: mark untranslated items and add original text as comment
        for file in files:            
            lu.Translate( "english_base.txt", file );
    
#   if len( sys.argv ) >=3:
