function dibuja(){
  // 'use strict';

  /* ChartJS
   * -------
   * Here we will create a few charts using ChartJS
   */

  //-----------------------
  //- MONTHLY SALES CHART -
  //-----------------------
  // Array.prototype.sample = function(){
  // return this[Math.floor(Math.random()*this.length)];
  // }
  // var paletteC = ["#605ca8","#dd4b39","#337ab7","#00c0ef","#00a65a","#f39c12",""];

  var months=["January","February","March","April","May","June","July","August","September","October","November","December"]
  var monthstring = [];
  var monthstring_r = [];
  for(var i=0; i < labelmonths.length; i++){
    monthstring.push(months[labelmonths[i]-1]);
  }
  var nummer_nrcs = [];
  nummer_nrcs=Array.from(new Set(nrc_curve));
  monthstring = Array.from(new Set(monthstring));
  var arr = []; 
  for(var i= 0; i<nummer_nrcs.length;i++){
    arr.push([]);
    for(var j=0; j<nrc_curve.length;j++){
      if(nummer_nrcs[i]==nrc_curve[j]){
        arr[i].push(data2[j])
      }
    }
  }
  

  var lineChartData = {
    labels: monthstring,
    datasets: [

    ]

  };
  for(var i=0;i<arr.length;i++){
    console.log(nummer_nrcs)
    var c = '#'+(Math.random().toString(16) + "000000").substring(2,8);
    var obj = {label:nummer_nrcs[i],fillColor:c,borderWidth:1,strokecolor:c,fillOpacity:97,pointcolor:c,pointStrokeColor:c,pointHighlightFill:c,pointHighlightStroke:c,data:arr[i]}
    lineChartData.datasets.push(obj)
  }
  var lineChartOptions = {
      //Boolean - If we should show the scale at all
      showScale: true,
      //Boolean - Whether grid lines are shown across the chart
      scaleShowGridLines: false,
      //String - Colour of the grid lines
      scaleGridLineColor: "rgba(0,0,0,.05)",
      //Number - Width of the grid lines
      scaleGridLineWidth: 1,
      //Boolean - Whether to show horizontal lines (except X axis)
      scaleShowHorizontalLines: true,
      //Boolean - Whether to show vertical lines (except Y axis)
      scaleShowVerticalLines: true,
      //Boolean - Whether the line is curved between points
      bezierCurve: true,
      //Number - Tension of the bezier curve between points
      bezierCurveTension: 0.3,
      //Boolean - Whether to show a dot for each point
      pointDot: false,
      //Number - Radius of each point dot in pixels
      pointDotRadius: 4,
      //Number - Pixel width of point dot stroke
      pointDotStrokeWidth: 1,
      //Number - amount extra to add to the radius to cater for hit detection outside the drawn point
      pointHitDetectionRadius: 20,
      //Boolean - Whether to show a stroke for datasets
      datasetStroke: true,
      //Number - Pixel width of dataset stroke
      datasetStrokeWidth: 2,
      //Boolean - Whether to fill the dataset with a color
      datasetFill: true,
      //String - A legend template
      legendTemplate: "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].lineColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>",
      //Boolean - whether to maintain the starting aspect ratio or not when responsive, if set to false, will take up entire container
      maintainAspectRatio: true,
      //Boolean - whether to make the chart responsive to window resizing
      responsive: true
    };

  //Create the line chart
   // Get context with jQuery - using jQuery's .get() method.
  var lineChartCanvas = $("#lineChart").get(0).getContext("2d");
  // This will get the first returned node in the jQuery collection.
  var lineChart = new Chart(lineChartCanvas);
  lineChartOptions.datasetFill = true;
  lineChart.Line(lineChartData, lineChartOptions);


  //---------------------------
  //- END MONTHLY SALES CHART -
  //---------------------------
}
// $(setTimeout(function(){
//   console.log(nrc_curve)
  
// },1000));
