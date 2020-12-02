

frontEnd: lex.yy.c parser.tab.c
	gcc parser.tab.c main.c -o frontEnd -lfl -DDEBUG

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lex.l
	flex lex.l

clean:
	rm lex.yy.c y.tab.c frontEnd