
update:
	bash update.sh

test-debug: update
	docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 debug

test-debug-polling: update
	docker run -t -i --rm -v ${PWD}:/app javanile/vtiger-dev:7.1.0 debug --polling

release: update
	bash release.sh
