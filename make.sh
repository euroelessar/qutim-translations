#!/bin/sh

STARTDIR=`pwd`
cd `dirname $0`

# Common vars
QUERY=$1
if [ "$QUERY" = "pack" ] || [ "$QUERY" = "just-pack" ];
then
	PACK=1
else
	PACK=0
fi
if [ "$QUERY" = "compile" ] || [ "$QUERY" = "pack" ];
then
	COMPILE=1
else
	COMPILE=0
fi
if [ "$QUERY" = "clean" ];
then
	CLEAN=1
else
	CLEAN=0
fi

# Packaging vars
URL_PREFIX="http://qutim.org/downloads/qutim-lang_"
URL_SUFFIX=".zip"
PLUGMAN_INFO='Pinfo.xml'

# Fill the list of languages
shift
if [ "$#" -gt "0" ];
then
	LANGUAGES="$@"
else
	LANGUAGES=`find . -mindepth 1 -maxdepth 1 -type d -not -name ".svn" -and -not -name "__trans" -and -not -name "__tmp" -and -not -name "debian" -print`
fi

# Check command
if [ "$COMPILE" -eq "0" ] && [ "$PACK" -eq "0" ] && [ "$CLEAN" -eq "0" ];
then
	echo "Usage:"
	echo "  ./make.sh command [language ...]"
	echo "Where:"
	echo "   * command - is one of the following:"
	echo "        compile - compile .ts files"
	echo "        pack - compile .ts files and create plugman packages"
	echo "        just-pack - create plugman packages from already compiled .ts files"
	echo "        clean - remove '__trans' and '__tmp' dirs"
	echo "   * language - optional parameter, specifies one or more languages to compile"
	echo "        if languages are not specified, all of them are compiled"
	cd $STARTDIR && exit 1
fi

# Package cleaning
if [ "$CLEAN" -eq "1" ];
then
	rm -rf __trans __tmp
	for language in $LANGUAGES;
	do
		rm -rf $language/binaries/*.qm
	done
	cd $STARTDIR && exit
fi

# A number of checks
if [ ! -x "`which sed`" ]
then
	echo "sed not found!!! Kill yourself, please!"
	cd $STARTDIR && exit 1
else
	SED=`which sed`
	echo "sed found in '$SED'"
fi
if [ "$PACK" -eq "1" ];
then
	if [ ! -x "`which zip`" ];
	then
		echo "zip not found!"
		cd $STARTDIR && exit 1
	else
		ZIP=`which zip`
		echo "zip found in '$ZIP'"
	fi
	if [ ! -x "`which svn`" ];
	then
		echo "svn not found!"
		cd $STARTDIR && exit 1
	else
		SVN=`which svn`
		echo "svn found in '$SVN'"
	fi
	if [ ! -x "`which awk`" ];
	then
		echo "awk not found!"
		cd $STARTDIR && exit 1
	else
		AWK=`which awk`
		echo "awk found in '$AWK'"
	fi
	if [ -d ".svn" ];
	then
		REV=`LANG=C $SVN info | $AWK '$1=="Revision:" {print $2;}'`
	else
		REV=`LANG=C $SVN info http://qutim.org/svn/languages | $AWK '$1=="Revision:" {print $2;}'`
	fi
fi
if [ "$COMPILE" -eq "1" ]
then
	if [ -x "`which lrelease-qt4`" ];
	then
		LRELEASE=`which lrelease-qt4`
		echo "lrelease found in '$LRELEASE'"
	else
		if [ -x "`which lrelease`" ];
		then
			LRELEASE=`which lrelease`
			echo "lrelease found in '$LRELEASE'"
		else
			echo 'lrelease not found!'
			cd $STARTDIR && exit 1
		fi
	fi
fi

for language in ${LANGUAGES};
do
	if [ "$COMPILE" -eq "1" ];
	then
		[ -d "${language}/binaries" ] || mkdir -p "${language}/binaries"
		for ts in `ls ${language}/sources/*.ts`; do
			qm="${language}/binaries/`basename $ts | sed 's/ts$/qm/'`"
			$LRELEASE $ts -qm $qm
		done
	fi
	if [ "$PACK" -eq "1" ];
	then
		[ -d "__trans" ] || mkdir -p "__trans"
		lang=`echo ${language} | sed 's@^\.\+/@@'`
		[ -d "__tmp/languages/${lang}" ] || mkdir -p "__tmp/languages/${lang}"
		cp ${language}/binaries/*.qm  __tmp/languages/${lang}/
		cp ${language}/${PLUGMAN_INFO} __tmp/
		cd __tmp
		sed -i "s@--VERSION--@${REV}@" ${PLUGMAN_INFO}
		URL=${URL_PREFIX}${lang}${URL_SUFFIX}
		sed -i "s@--URL--@${URL}@" ${PLUGMAN_INFO}
		zip -r ../__trans/qutim-lang_${lang}.zip *
		cd ..
		rm -rf __tmp
	fi
done
