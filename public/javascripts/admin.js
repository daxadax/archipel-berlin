$(document).ready(function(){
  // nav bar
  $('#dashboard #main-nav .nav-item').on('click', function() {
    var option = this.attributes.data.textContent;

    $('#dashboard #main-nav .nav-item').removeClass('active btn-default')
    this.classList.add('active',  'btn-default')

    $('#dashboard section').addClass('hidden');
    document.getElementById(option).classList.remove('hidden');
  });
});


function regenerateReports(date) {
  $.ajax({
    url: '/admin/generate_reports',
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

function toggleDeliveryRequest(e) {
  detailsRow = e.closest('tr').nextElementSibling;
  $(detailsRow).toggleClass('hidden');
}
