$(function () {
  'use strict'

  var ticksStyle = {
    fontColor: '#495058',
    fontStyle: 'bold'
  }

  var mode      = 'index'
  var intersect = true

  var $salesChart = $('#sales-chart')
  var salesChart  = new Chart($salesChart, {
    type   : 'bar',
    data   : {
      labels: ['Ocak', 'Şubat', 'Mart', 'Nisan',  'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'],
      datasets: [
        {
          backgroundColor: '#007bff',
          borderColor    : '#007bff',
          data: [3736, 4165, 2208, 168, 15, 1116, 33, 9341, 15484, 14130, 5390, 4919]
        },
        {
          backgroundColor: '#ced4da',
          borderColor    : '#ced4da',
          data: [4724, 4406, 7138, 7126, 2021, 10397, 39507, 38536, 35618, 38961, 15342, 11098]
        },
        {
          backgroundColor: '#245878',
          borderColor: '#245878',
          data: [1111, 2222, 3333, 4444, 5555, 666, 7777, 8888, 9999, 434, 3453, 2324]
        },
        {
          backgroundColor: '#878954',
          borderColor: '#11d4da',
          data: [4724, 4406, 100, 7126, 2021, 10397, 39507, 38536, 35618, 38961, 15342, 11098]
        },
        {
          backgroundColor: 'cyan',
          borderColor: 'cyan',
          data: [4724, 4406, 7138, 7126, 2021, 10397, 39507, 38536, 35618, 38961, 15342, 11098]
        }, 
        {
          backgroundColor: '#987452',
          borderColor: '#987452',
          data: [4724, 4406, 7138, 7126, 2021, 10397, 39507, 38536, 35618, 38961, 15342, 11098]
        }, 
        {
          backgroundColor: '#879545',
          borderColor: '#879545',
          data: [4724, 4406, 7138, 7126, 2021, 10397, 39507, 38536, 35618, 38961, 15342, 11098]
        }, 
        {
          backgroundColor: '#001548',
          borderColor: '#001548',
          data: [4724, 4406, 7138, 7126, 2021, 10397, 39507, 38536, 35618, 38961, 15342, 11098]
        }, 
        {
          backgroundColor: '#654875',
          borderColor: '#654875',
          data: [4724, 4406, 7138, 7126, 2021, 10397, 39507, 38536, 35618, 38961, 15342, 11098]
        }, 
        {
          backgroundColor: '#aabc74',
          borderColor: '#aabc74',
          data: [4724, 4406, 7138, 7126, 2021, 10397, 39507, 38536, 35618, 38961, 15342, 11098]
        },
      ]
    },
    options: {
      maintainAspectRatio: false,
      tooltips           : {
        mode     : mode,
        intersect: intersect
      },
      hover              : {
        mode     : mode,
        intersect: intersect
      },
      legend             : {
        display: false
      },
      scales             : {
        yAxes: [{
          // display: false,
          gridLines: {
            display      : true,
            lineWidth    : '4px',
            color        : 'rgba(0, 0, 0, .2)',
            zeroLineColor: 'transparent'
          },
          ticks    : $.extend({
            beginAtZero: true,

            // Include a dollar sign in the ticks
            callback: function (value, index, values) {
              if (value >= 1000) {
                value /= 1000
                value += 'K'
              }
              return '' + value
            }
          }, ticksStyle)
        }],
        xAxes: [{
          display  : true,
          gridLines: {
            display: false
          },
          ticks    : ticksStyle
        }]
      }
    }
  })

  var $visitorsChart = $('#visitors-chart')
  var visitorsChart  = new Chart($visitorsChart, {
    data   : {
      labels  : ['18th', '20th', '22nd', '24th', '26th', '28th', '30th'],
      datasets: [{
        type                : 'line',
        data                : [100, 120, 170, 167, 180, 177, 160],
        backgroundColor     : 'transparent',
        borderColor         : '#007bff',
        pointBorderColor    : '#007bff',
        pointBackgroundColor: '#007bff',
        fill                : false
        // pointHoverBackgroundColor: '#007bff',
        // pointHoverBorderColor    : '#007bff'
      },
        {
          type                : 'line',
          data                : [60, 80, 70, 67, 80, 77, 100],
          backgroundColor     : 'tansparent',
          borderColor         : '#ced4da',
          pointBorderColor    : '#ced4da',
          pointBackgroundColor: '#ced4da',
          fill                : false
          // pointHoverBackgroundColor: '#ced4da',
          // pointHoverBorderColor    : '#ced4da'
        }]
    },
    options: {
      maintainAspectRatio: false,
      tooltips           : {
        mode     : mode,
        intersect: intersect
      },
      hover              : {
        mode     : mode,
        intersect: intersect
      },
      legend             : {
        display: false
      },
      scales             : {
        yAxes: [{
          // display: false,
          gridLines: {
            display      : true,
            lineWidth    : '4px',
            color        : 'rgba(0, 0, 0, .2)',
            zeroLineColor: 'transparent'
          },
          ticks    : $.extend({
            beginAtZero : true,
            suggestedMax: 200
          }, ticksStyle)
        }],
        xAxes: [{
          display  : true,
          gridLines: {
            display: false
          },
          ticks    : ticksStyle
        }]
      }
    }
  })
})
