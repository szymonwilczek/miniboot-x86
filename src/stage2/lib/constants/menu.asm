%ifndef CONSTANTS_MENU
%define CONSTANTS_MENU

MENU_COUNT equ 4

menu_opt_0: db "Minimal Linux Kernel", 0
menu_opt_1: db "Miniboot Diagnostic Shell", 0
menu_opt_2: db "UEFI-like Setup Utility", 0
menu_opt_3: db "Reboot System", 0 ; probably I will rework that to be command instead of choice in menu

menu_table:
	dw menu_opt_0
	dw menu_opt_1
	dw menu_opt_2
	dw menu_opt_3

selected_item: db 0 ; index of currently selected position

selected_mark: db "  [X] ", 0
not_selected_mark: db "  [ ] ", 0
navigation_hint: db "Use UP/DOWN arrows to navigate, ENTER to select", 0

%endif
