$(document).ready(function() {
  var colum_names=[];
  columnas = document.getElementById("addRowTable").rows[0].cells;
  for (var i = 0; i <columnas.length; i++) {
    colum_names.push(columnas[i].getAttribute("name"));
  }
  console.log(colum_names)
  //colum_names = ["name", "last_name", "email", "saldo", "codigo"];
  var flag = true;
  var entrada;
  var celda_actual;
  var posicion;
  // Tabla para inserta
  var tableNew = $('#addRowTable').DataTable( {
      keys: true,
      bFilter: false,
      bLengthChange: false,
      bPaginate: false,
      bInfo: false
  } );

  //Add new row
   $('#addRow').on( 'click', function () {
    budget = $('#set_budget').val();
    console.log(budget);
    tableNew.row.add(['','','@uninorte.edu.co',budget,0]).draw(false); //ERROR PORQUE DESAPARECE LA COLUMNA PARA HTML
  } );
  $('#addStudent').on( 'click', function () {
    datos = tableNew.data();
    
    for (var j = 0; j < datos.length; j++) {
      enviar = {};
      console.log('datos: ', datos[j]);
      for (var i = 0; i < colum_names.length; i++) {
        enviar[colum_names[i]] = datos[j][i];
      }
      //Se envia usuario uno por uno
      c_error = 0;
      $.ajax({
        type: 'GET',
        url: 'newStudents',
        data: enviar,
        success: function(){
          tableNew.clear();
          tableNew.draw();
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          if (c_error<1) {
            alert("Please check your data");
            c_error += 1;
          }
           
        }
      }); 
    }
    
    
  } );
  //---------
 
    tableNew
        .on( 'key', function ( e, datatable, key, cell, originalEvent ) {
            //events.prepend( '<div>Key press: '+key+' for cell <i>'+cell.data()+'</i></div>' );
            //console.log(key);
            if(key != 13){
              if(flag){
                var value = cell.data();
                if(cell.index().column == colum_names.indexOf("saldo") || cell.index().column == colum_names.indexOf("codigo")){
                  cell.data('<input id="intro2" type="number" step="10" min="0.0">')
                } else if(cell.index().column == colum_names.indexOf("email")){
                  cell.data('<input id="intro2" type="email" name="email" value="'+value+'">')
                } else{
                  cell.data('<input id="intro2" type="text" name="" value="'+value+'">')
                }
              
              $("#intro2").focus();
              flag = false;
              tableNew.keys.disable();
              }
            }else{
              posicion = celda_actual.index().row*5 + celda_actual.index().column + 1;
              tableNew.cell( ':eq('+posicion+')' ).focus();
            }

        } )
        .on( 'key-focus', function ( e, datatable, cell ) {
          celda_actual = cell;
        } )
        .on( 'key-blur', function ( e, datatable, cell ) {
        } )

      window.onkeyup = function(e) {
     var key = e.keyCode ? e.keyCode : e.which;

     if (key == 13) {
        if(flag == false){
          entrada = document.getElementById("intro2").value;
          celda_actual.data(entrada);
          flag = true;
          tableNew.keys.enable();
          // PASAR A SIGUIENTE CELDA
          var posicion = celda_actual.index().row*5 + celda_actual.index().column + 1;
          tableNew.cell( ':eq('+posicion+')' ).focus();
        }
         
     }
  }
} );