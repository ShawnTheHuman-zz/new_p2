

frontEnd: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o frontEnd

y.tab.c y.tab.h: parser.y
	bison -d parser.y

lex.yy.c: parser.l
	lex parser.l

clean:
	rm lex.yy.c y.tab.c frontEnd