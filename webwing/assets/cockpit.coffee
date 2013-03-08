class window.Cockpit

  @init: () =>
    cockpit = $('.cockpit-overlay')
    cockpit.append($('<div class="target-display"/>'))
    cockpit.append($('<div class="radar-front circle"/>'))
    cockpit.append($('<div class="radar-back circle"/>'))