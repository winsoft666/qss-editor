QT  += core gui svg

TARGET      = example
TEMPLATE    = app
DESTDIR     = $$PWD/../bin

# Comment this in to build a dynamic library supporting multiple architectures
# on macOS.
#QMAKE_APPLE_DEVICE_ARCHS = x86_64 arm64

HEADERS      = mainwindow.h
SOURCES      = main.cpp mainwindow.cpp
RESOURCES    = example.qrc

INCLUDEPATH += $$PWD/../src/
CONFIG(debug, debug|release) {
	LIBS += -L$$PWD/../bin/ -lqscintilla2_qt5d
} else {
	LIBS += -L$$PWD/../bin/ -lqscintilla2_qt5
}