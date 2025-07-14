BIN := test

CC := g++
CFLAGS := -Wall -Wextra

SYSTEMC_HOME := /opt/systemc-2.3.4
# TODO: Design a pattern to determine the arch and set the correct loader directory name
lib := lib-linuxaarch64
INCLUDE_DIR := ${SYSTEMC_HOME}/include
LINK_DIR := ${SYSTEMC_HOME}/${lib}
BUILD_DIR := build

SRC := test.cpp
OBJ := $(BUILD_DIR)/$(SRC:.cpp=.o)

.PHONY: all clean

all: $(BUILD_DIR)/$(BIN)
	./$(BUILD_DIR)/$(BIN)

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(BUILD_DIR)
	$(CC) -c $(CFLAGS) $< -I$(INCLUDE_DIR) -o $@

$(BUILD_DIR)/$(BIN): $(OBJ)
	$(CC) $^ -L${LINK_DIR} -lsystemc -Wl,-rpath,$(LINK_DIR) -o $@

clean:
	rm -rf $(BUILD_DIR)