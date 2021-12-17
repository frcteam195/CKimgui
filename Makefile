#
# Cross Platform Makefile
# Compatible with MSYS2/MINGW, Ubuntu 14.04.1 and Mac OS X
#
# You will need SDL2 (http://www.libsdl.org):
# Linux:
#   apt-get install libsdl2-dev
# Mac OS X:
#   brew install sdl2
# MSYS2:
#   pacman -S mingw-w64-i686-SDL2
#

#CXX = g++
#CXX = clang++

source = ./
header_target = /usr/local/include/imgui/
lib_target = /usr/local/lib/

IMGUI_DIR = .
LIB = libimgui.a
SOURCES += $(wildcard $(IMGUI_DIR)/*.cpp)
SOURCES += $(wildcard $(IMGUI_DIR)/backends/*.cpp)
SOURCES += $(wildcard $(IMGUI_DIR)/misc/cpp/*.cpp)
#Remove the targets we don't care about one by one so they can be added back easily, if needed
SOURCES := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_dx*.cpp), $(SOURCES))
SOURCES := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_wgpu.cpp), $(SOURCES))
SOURCES := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_android.cpp), $(SOURCES))
SOURCES := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_win32.cpp), $(SOURCES))
SOURCES := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_allegro5.cpp), $(SOURCES))
SOURCES := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_marmalade.cpp), $(SOURCES))
SOURCES := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_metal.cpp), $(SOURCES))



HEADERS += $(wildcard $(IMGUI_DIR)/*.h)
HEADERS += $(wildcard $(IMGUI_DIR)/backends/*.h)
HEADERS += $(wildcard $(IMGUI_DIR)/misc/cpp/*.h)
#Remove the targets we don't care about one by one so they can be added back easily, if needed
HEADERS := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_dx*.h), $(HEADERS))
HEADERS := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_wgpu.h), $(HEADERS))
HEADERS := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_android.h), $(HEADERS))
HEADERS := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_win32.h), $(HEADERS))
HEADERS := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_allegro5.h), $(HEADERS))
HEADERS := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_marmalade.h), $(HEADERS))
HEADERS := $(filter-out $(wildcard $(IMGUI_DIR)/backends/*_metal.h), $(HEADERS))



OBJS = $(addsuffix .o, $(basename $(notdir $(SOURCES))))
UNAME_S := $(shell uname -s)

CXXFLAGS = -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
CXXFLAGS += -g -Wall -Wformat -fPIC
LIBS =

##---------------------------------------------------------------------
## OPENGL ES
##---------------------------------------------------------------------

## This assumes a GL ES library available in the system, e.g. libGLESv2.so
# CXXFLAGS += -DIMGUI_IMPL_OPENGL_ES2
# LINUX_GL_LIBS = -lGLESv2
## If you're on a Raspberry Pi and want to use the legacy drivers,
## use the following instead:
# LINUX_GL_LIBS = -L/opt/vc/lib -lbrcmGLESv2

##---------------------------------------------------------------------
## BUILD FLAGS PER PLATFORM
##---------------------------------------------------------------------

ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += $(LINUX_GL_LIBS) -ldl `sdl2-config --libs`

	CXXFLAGS += `sdl2-config --cflags`
	CFLAGS = $(CXXFLAGS)
endif

ifeq ($(UNAME_S), Darwin) #APPLE
	ECHO_MESSAGE = "Mac OS X"
	LIBS += -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo `sdl2-config --libs`
	LIBS += -L/usr/local/lib -L/opt/local/lib

	CXXFLAGS += `sdl2-config --cflags`
	CXXFLAGS += -I/usr/local/include -I/opt/local/include
	CFLAGS = $(CXXFLAGS)
endif

ifeq ($(OS), Windows_NT)
    ECHO_MESSAGE = "MinGW"
    LIBS += -lgdi32 -lopengl32 -limm32 `pkg-config --static --libs sdl2`

    CXXFLAGS += `pkg-config --cflags sdl2`
    CFLAGS = $(CXXFLAGS)
endif

##---------------------------------------------------------------------
## BUILD RULES
##---------------------------------------------------------------------

%.o:%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/backends/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<
	
%.o:$(IMGUI_DIR)/misc/cpp/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

all: $(LIB)
	@echo Build complete for $(ECHO_MESSAGE)

$(LIB): $(OBJS)
	ar -rv $@ $^ 

clean:
	rm -f $(LIB) $(OBJS)

install: $(LIB)
	@for item in $(HEADERS) ; do install $${item} -Dv $(header_target)$${item#$(source)} ; done
	install libimgui.a -Dv $(lib_target)libimgui.a
