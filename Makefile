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

EXE = $(BIN_DIR)/example_sdl_opengl2
IMGUI_DIR = include/imgui
BACKEND_DIR = include/backends
SOURCE_DIR = src
BUILD_DIR = build
BIN_DIR = bin

SOURCES = $(shell find $(SOURCE_DIR) -name *.cpp)
#IMGUI LIBRARY CLASSES
SOURCES += $(IMGUI_DIR)/imgui.cpp $(IMGUI_DIR)/imgui_demo.cpp $(IMGUI_DIR)/imgui_draw.cpp $(IMGUI_DIR)/imgui_tables.cpp $(IMGUI_DIR)/imgui_widgets.cpp
#IMGUI BACKEND HELPER CLASSES
SOURCES += $(BACKEND_DIR)/imgui_impl_sdl.cpp $(BACKEND_DIR)/imgui_impl_opengl2.cpp
OBJS = $(addsuffix .o, $(basename $(SOURCES)))
DEPS := $(OBJS:.o=.d)

-include $(DEPS)

MKDIR_P ?= mkdir -p
UNAME_S := $(shell uname -s)

CXXFLAGS = -std=c++11 -I$(IMGUI_DIR) -I$(BACKEND_DIR)
CXXFLAGS += -g -Wall -Wformat
LIBS =

##---------------------------------------------------------------------
## BUILD FLAGS PER PLATFORM
##---------------------------------------------------------------------

ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += -lGL -ldl `sdl2-config --libs`

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

$(BUILD_DIR)/%.o:$(SOURCE_DIR)/%.cpp
	$(MKDIR_P) $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o:$(IMGUI_DIR)/%.cpp
	$(MKDIR_P) $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o:$(BACKEND_DIR)/%.cpp
	$(MKDIR_P) $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

all: $(EXE)
	@echo Build complete for $(ECHO_MESSAGE)

$(EXE): $(OBJS)
	$(MKDIR_P) $(BIN_DIR)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LIBS)

install:
	@echo Install not implemented

run: $(EXE)
	$(EXE)

clean:
	rm -f $(EXE) $(OBJS)
