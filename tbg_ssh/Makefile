tbg_ssh_cfg_prefix := ~/.tbg/tbg_ssh
tbg_ssh_exec := /usr/bin/tbg_ssh

.PHONY: install
install:
	ln -sf $(shell pwd)/tbg_ssh.pl $(tbg_ssh_exec)
	mkdir -p $(tbg_ssh_cfg_prefix)
	cp -n ./tbg_ssh.json $(tbg_ssh_cfg_prefix)/tbg_ssh.json

.PHONY: uninstall
uninstall:
	-rm -rf $(tbg_ssh_cfg_prefix)
	-rm $(tbg_ssh_exec)
