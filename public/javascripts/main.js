$(document).ready(function() {
  // log the screen width on resize
  window.onresize = function(event) {
    console.log("window width: "+$(window).width()+"px");
  };

  // display notification if one exists
  var notification = document.getElementById('notification');
  var notificationMessage = notification.getAttribute('data-message');
  var notificationType = notification.getAttribute('data-type');

  if (notificationMessage) {
    notify(notificationMessage, notificationType);
  };
});

// msg: what do you want to notify the user about?
// type: one of bootstrap alert types (getbootstrap.com/docs/4.0/components/alerts)
function notify(msg, type = 'info') {
  var element = document.getElementById('notification');
      title = getTitleForType(type);

  // remove previous alert styles
  element.classList.forEach(function(klass) {
    if (klass.match(/alert-*/)) {
      element.classList.remove(klass);
    }
  });

  $("#notification").addClass('alert-' + type);
  $("#notification .alert-heading").html(title);
  $("#notification .message").html(msg);
  $("#notification").fadeIn("slow").fadeOut(6000);
}

function getTitleForType(type) {
  switch(type) {
    case "warning": return "Uh-oh!";
    case "danger": return "Uh-oh!";
    case "success": return "Nice one!";
    default: return "Heads up!";
  }
}

// https://stackoverflow.com/a/3067896/2128691
Date.prototype.yyyymmdd = function() {
  var mm = this.getMonth() + 1; // getMonth() is zero-based
  var dd = this.getDate();

  return [this.getFullYear(),
          (mm>9 ? '' : '0') + mm,
          (dd>9 ? '' : '0') + dd
         ].join('/');
};
