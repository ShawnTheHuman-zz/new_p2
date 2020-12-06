

frontEnd: lex.yy.c parser.tab.c
	gcc -o frontEnd parser.tab.c main.c -lfl -DDEBUG

parser.tab.c parser.tab.h: parser.y
	bison -d -t parser.y

lex.yy.c: lex.l
	flex lex.l

clean:
	rm lex.yy.c y.tab.c frontEnd