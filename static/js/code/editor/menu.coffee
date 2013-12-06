# Populate the menu.
menu = ['tree', 'console', 'save', 'search']
html = ''
for key in menu
	html += '<div id="' + key + 'Button" class="menu">' + icons[key] + '</div>'
setHtml getElement('menu'), html
toggleClass 'treeButton', 'toggle'
toggleClass 'saveButton', 'disabled'

# Last button to be clicked.
lastClickedButton = 0

# When a menu item is clicked, toggle it and turn all others off.
delegate 'menu', 'div.menu', 'click', (event, menu, clickedButton) ->
	if not hasClass clickedButton, 'disabled'
		lastClickedButton = clickedButton
		turnOn = not hasClass clickedButton, 'on'
		buttons = getChildren menu
		for button in buttons
			flipButton button, if button == clickedButton then turnOn else false

		if clickedButton.id is 'saveButton'
			saveFile()

# Turn a button on or off.
flipButton = (button, turnOn) ->
	if hasClass button, 'toggle'
		flipClass button, 'on', turnOn
		if area = getElement button.id.replace 'Button', ''
			flipClass area, 'on', turnOn

# Turn the last clicked button on an editor click.
bind 'editor', 'mousedown', ->
	flipButton lastClickedButton

# Enable or disable the save button
enableSaveButton = (enable) ->
		disabled = not enable
		flipClass 'saveButton', 'disabled', disabled