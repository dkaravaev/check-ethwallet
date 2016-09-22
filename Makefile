install: # balance_ui-ru.mo
	install balance balance_ui /usr/local/bin
	which gdialog >/dev/null 2>&1 || install gdialog /usr/local/bin
	# grep -q "`cat balance.services`" /etc/services || cat balance.services >> /etc/services
	# install balance.xinetd /etc/xinetd.d/balance
	# ln -sf /usr/local/bin/balance_ui /usr/local/bin/nbalance_ui
	# install balance_ui-ru.mo /usr/share/locale/ru/LC_MESSAGES/balance_ui.mo

# balance_ui.pot: balance_ui
	# xgettext -o balance_ui.pot -L Shell balance_ui

# balance_ui-ru.mo: balance_ui-ru.po
	# msgfmt balance_ui-ru.po -o balance_ui-ru.mo 


uninstall:
	rm -f /usr/local/bin/balance \
		  /usr/local/bin/balance_ui \
		  /usr/local/bin/gdialog 