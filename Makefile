ifeq ($(shell which erl),)
$(error Can't find Erlang executable 'erl')
exit 1
endif

PY2=python2.7
PY2_VENV=./.venv-py2
ESCRIPT=$(shell which escript)
IPY_KERN=./bin/ipython_kernel

py2venv:
	@virtualenv --python=$(PY2) $(PY2_VENV)

py2deps: py2venv
	@. $(PY2_VENV)/bin/activate && \
	pip install -r requirements.txt

compile:
	@echo "Compiling IErlang..."
	@rebar get-deps
	@rebar compile

py2notebook: py2deps compile
	@echo "Starting IErlang Notebook..."
	@. $(PY2_VENV)/bin/activate && \
	cd src && \
	ERL_LIBS=$(ERL_LIBS):deps/erlzmq:deps/mochiweb:../ierlang \
	ipython2 notebook \
	--KernelManager.kernel_cmd='["$(ESCRIPT)", "$(IPY_KERN)", "{connection_file}"]' \
	--Session.key="" \
	--Session.keyfile=""

py2shell: py2deps compile
	@echo "Starting IErlang Console..."
	@. $(PY2_VENV)/bin/activate && \
	cd src && \
	ERL_LIBS=$(ERL_LIBS):deps/erlzmq:deps/mochiweb:../ierlang \
	ipython2 console \
	--KernelManager.kernel_cmd='["$(ESCRIPT)", "$(IPY_KERN", "{connection_file}"]' \
	--Session.key="" \
	--Session.keyfile=""
