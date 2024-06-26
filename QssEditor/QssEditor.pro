TARGET = QssEditor
TEMPLATE = app

QT += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets printsupport


macx {
    QT *= macextras
}

NVER1=1
NVER2=0
NVER3=1

!win32:!unix {
    error("QSS Editor must be compiled on Windows or Linux/Mac")
}

VERSION=$$sprintf("%1.%2.%3", $$NVER1, $$NVER2, $$NVER3)

DEFINES += NVER1=$$NVER1
DEFINES += NVER2=$$NVER2
DEFINES += NVER3=$$NVER3
DEFINES += NVER_STRING=$$sprintf("\"\\\"%1\\\"\"", $$VERSION)

# require at least Windows XP
win32:DEFINES += _WIN32_WINNT=0x0501 WINVER=0x0501

# use fast string concat
DEFINES *= QT_USE_QSTRINGBUILDER

win32 {
    SEP="\\"
} unix {
    SEP="/"
}

win32 {
    LANGUAGES=$$system(dir /B \"$${_PRO_FILE_PWD_}\\ts\\*.ts\")
} else {
    LANGUAGES=$$system(find \"$${_PRO_FILE_PWD_}/ts/\" -name \"*.ts\" -printf \"%f \")
}

LANGUAGES=$$replace(LANGUAGES, .ts, )

# search an executable in PATH
defineReplace(findexeWin32) {
    return ( $$system(for %i in ($${1}.exe) do @echo. %~$PATH:i) )
}

defineReplace(findexeUnix) {
    return ( $$system(which $$1) )
}

# escape command to allow multiple lines in Makefile
defineReplace(mle) {
    return ( $$1$$escape_expand(\\n\\t) )
}

for(ts, LANGUAGES) {
    win32 {
        LRELEASE="$$[QT_INSTALL_BINS]\\lrelease.exe"
        LUPDATE="$$[QT_INSTALL_BINS]\\lupdate.exe"
        MTRANSLATIONS += $${_PRO_FILE_PWD_}\\ts\\$${ts}.ts
    } else {
        LRELEASE=$$system(which lrelease)
        LUPDATE=$$system(which lupdate)
        MTRANSLATIONS += $${_PRO_FILE_PWD_}/ts/$${ts}.ts
    }
}

message(Translations: $$MTRANSLATIONS)

# copy translations
!isEmpty(LUPDATE) {
    message("lupdate is found, will update the translations")
    QMAKE_POST_LINK += $$mle($$LUPDATE -no-obsolete $$_PRO_FILE_ -ts $$MTRANSLATIONS)
}

# lrelease for each ts
!isEmpty(LRELEASE) {
    win32 {
        TRANSLATIONS_DIR="$${OUT_PWD}/$(DESTDIR_TARGET)/../translations"
        QMAKE_POST_LINK += $$mle(if not exist \"$$TRANSLATIONS_DIR\" mkdir \"$$TRANSLATIONS_DIR\")

        for(ts, LANGUAGES) {
            QMAKE_POST_LINK += $$mle($$LRELEASE \"$${_PRO_FILE_PWD_}\\ts\\$${ts}.ts\" -qm \"$$TRANSLATIONS_DIR\\$${ts}.qm\")
            QMAKE_POST_LINK += $$mle(copy /Y \"$${_PRO_FILE_PWD_}\\ts\\$${ts}.png\" \"$$TRANSLATIONS_DIR\\$${ts}.png\")
        }

        QMAKE_POST_LINK += $$mle(copy /Y \"$${_PRO_FILE_PWD_}\\ts\\translations.conf\" \"$$TRANSLATIONS_DIR\\\")
    } else {
        TRANSLATIONS_DIR="$${OUT_PWD}/translations"
        QMAKE_POST_LINK += $$mle(mkdir -p \"$$TRANSLATIONS_DIR\")

        for(ts, LANGUAGES) {
            QMAKE_POST_LINK += $$mle($$LRELEASE \"$${_PRO_FILE_PWD_}/ts/$${ts}.ts\" -qm \"$$TRANSLATIONS_DIR/$${ts}.qm\")
            QMAKE_POST_LINK += $$mle(cp -f \"$${_PRO_FILE_PWD_}/ts/$${ts}.png\" \"$$TRANSLATIONS_DIR/$${ts}.png\")
        }

        QMAKE_POST_LINK += $$mle(cp -f \"$${_PRO_FILE_PWD_}/ts/translations.conf\" \"$$TRANSLATIONS_DIR/\")
    }
}

#include($$_PRO_FILE_PWD_/QssEditor-common.pri)

INCLUDEPATH += $$PWD/../QScintilla/src

CONFIG(debug, debug|release) {
    LIBS += -L$$PWD/../QScintilla/bin/ -lqscintilla2_qt5d
} else {
    LIBS += -L$$PWD/../QScintilla/bin/ -lqscintilla2_qt5
}

SOURCES += main.cpp \
    qsseditor.cpp \
    qscilexerqss.cpp \
    project.cpp \
    settings.cpp \
    searchandreplace.cpp \
    options.cpp \
    about.cpp

HEADERS += qsseditor.h \
    qscilexerqss.h \
    project.h \
    settings.h \
    searchandreplace.h \
    options.h \
    about.h \
    tools.h

FORMS += qsseditor.ui \
    searchandreplace.ui \
    options.ui \
    about.ui

RESOURCES += qsseditor.qrc \
    theme/dark/darkstyle.qrc \
    theme/light/lightstyle.qrc

RC_FILE = qsseditor.rc


OTHER_FILES += \
    LICENSE.txt \
    README.txt

