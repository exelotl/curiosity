NAME=ld26

all:
	rock ld26.use -v -g -o=$(NAME)

release_win32:
	rock ld26.use -v -o=$(NAME) +-O2

release_linux_x86:
	rock ld26.use -v -o=$(NAME) -m32 +-Wl,-R,libs +-O2

release_linux_x64:
	rock ld26.use -v -o=$(NAME) -m64 +-Wl,-R,libs +-O2

test: all
	gdb -ex run ./$(NAME)

clean:
	rm -f $(NAME)
	rm -rf .libs/ rock_tmp/