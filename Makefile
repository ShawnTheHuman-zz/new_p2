all:
	$(MAKE) flex
	$(MAKE) grammar
	gcc parser.tab.c main.c -o frontEnd -lfl -DDEBUG
grammar:
	bison -d parser.y
flex:
	flex lex.l
test: