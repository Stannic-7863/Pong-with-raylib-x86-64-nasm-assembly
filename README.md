A simple project I did to learn x86-64 assembly

To run it on linux do:
```
nasm -f elf64 raylib_in_asm.asm 
```
Raylib must be installed on the system, else provide path to raylib using `-L/path/to/raylib`
```
gcc -no-pie -o raylib_with_asm raylib_in_asm.o -lraylib -lm
```

```
./raylib_with_asm
```
