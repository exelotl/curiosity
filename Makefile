NAME = curiosity

all:
	rock $(NAME).use -v -g -o=$(NAME)

release_win32:
	rock $(NAME).use -v -o=$(NAME) +-O2

release_linux_x86:
	rock $(NAME).use -v -o=$(NAME) -g -m32 +-Wl,-R,libs +-O2

release_linux_x64:
	rock $(NAME).use -v -o=$(NAME) -g -m64 +-Wl,-R,libs +-O2

release_osx:
	rock $(NAME).use -v -o=$(NAME) -g +-O2

test: all
	gdb -ex run ./$(NAME)

clean:
	rm -f $(NAME)
	rm -rf .libs rock_tmp

