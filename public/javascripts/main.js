$(document).ready(function() {
  // log the screen width on resize
  window.onresize = function(event) {
    console.log("window width: "+$(window).width()+"px");
  };
});

function regenerateReports(date) {
  $.ajax({
    url: '/generate_reports',
    method: 'post',
    data: {
      date: date
    },
    success: window.location.reload()
  })
}

function toggleOrderSummary(e) {
  orderSummaryRow = e.closest('tr').nextElementSibling;
  $(orderSummaryRow).toggleClass('hidden');
}
