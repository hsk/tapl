all:
	cd 11arith ; make
	cd 12untyped ; make
	cd 13fulluntyped ; make
	cd 21tyarith ; make
	cd 22simplebool ; make
	cd 23fullsimple ; make
	cd 31purefsub ; make
	cd 32fullsub ; make
	cd 33bot ; make
	cd 34rcdsubbot ; make
	cd 35fullref ; make
	cd 36fullerror ; make
	cd 41equirec ; make
	cd 42fullequirec ; make
	cd 43fullisorec ; make
	cd 51reconbase ; make
	cd 52recon ; make
	cd 53fullrecon ; make
	cd 54fullpoly ; make
	cd 61fomega ; make
	cd 62fullomega ; make
	cd 63fullfsub ; make
	cd 64fullfsubref ; make
	cd 65fomsub ; make
	cd 66fullfomsub ; make
	cd 67fullfomsubref ; make
	cd 70fullupdate ; make
	cd joinexercise ; make
	cd letexercise ; make

clean:
	cd 11arith ; make clean
	cd 12untyped ; make clean
	cd 13fulluntyped ; make clean
	cd 21tyarith ; make clean
	cd 22simplebool ; make clean
	cd 23fullsimple ; make clean
	cd 31purefsub ; make clean
	cd 32fullsub ; make clean
	cd 33bot ; make clean
	cd 34rcdsubbot ; make clean
	cd 35fullref ; make clean
	cd 36fullerror ; make clean
	cd 41equirec ; make clean
	cd 42fullequirec ; make clean
	cd 43fullisorec ; make clean
	cd 51reconbase ; make clean
	cd 52recon ; make clean
	cd 53fullrecon ; make clean
	cd 54fullpoly ; make clean
	cd 61fomega ; make clean
	cd 62fullomega ; make clean
	cd 63fullfsub ; make clean
	cd 64fullfsubref ; make clean
	cd 65fomsub ; make clean
	cd 66fullfomsub ; make clean
	cd 67fullfomsubref ; make clean
	cd 70fullupdate ; make clean
	cd joinexercise ; make clean
	cd letexercise ; make clean
	rm -rf Node_modules
test:
	echo "----" ; cd 11arith ; make test
	echo "----" ; cd 12untyped ; make test
	echo "----" ; cd 13fulluntyped ; make test
	echo "----" ; cd 21tyarith ; make test
	echo "----" ; cd 22simplebool ; make test
	echo "----" ; cd 23fullsimple ; make test
	echo "----" ; cd 31purefsub ; make test
	echo "----" ; cd 32fullsub ; make test
	echo "----" ; cd 33bot ; make test
	echo "----" ; cd 34rcdsubbot ; make test
	echo "----" ; cd 35fullref ; make test
	echo "----" ; cd 36fullerror ; make test
	echo "----" ; cd 41equirec ; make test
	echo "----" ; cd 42fullequirec ; make test
	echo "----" ; cd 43fullisorec ; make test
	echo "----" ; cd 51reconbase ; make test
	echo "----" ; cd 52recon ; make test
	echo "----" ; cd 53fullrecon ; make test
	echo "----" ; cd 54fullpoly ; make test
	echo "----" ; cd 61fomega ; make test
	echo "----" ; cd 62fullomega ; make test
	echo "----" ; cd 63fullfsub ; make test
	echo "----" ; cd 64fullfsubref ; make test
	echo "----" ; cd 65fomsub ; make test
	echo "----" ; cd 66fullfomsub ; make test
	echo "----" ; cd 67fullfomsubref ; make test
	echo "----" ; cd 70fullupdate ; make test
#	cd joinexercise ; make test
#	cd letexercise ; make test
	osascript -e 'display notification "test ok" with title "Make test" subtitle "" sound name "Purr"'
watch:
	make test || osascript -e 'display notification "test error" with title "Make test" '
	@echo 🐫  Watching for changes...
	@fswatch -1 .
	make test || osascript -e 'display notification "test error" with title "Make test" '
	make watch

node_modules:
	npm install
grunt: node_modules
	grunt

