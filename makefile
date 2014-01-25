test: build
	@mocha -R spec --recursive   
commit: build
	@git add .
	@git commit -am "update `date`" | :
push: commit
	@git push origin --all
doc: src
	@codo -o doc src
build: src
	@coffee -c -b -m -o lib src

.PHONY: doc

