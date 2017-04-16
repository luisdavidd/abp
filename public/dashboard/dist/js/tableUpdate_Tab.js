$(document).ready(function() {
  var colum_names=[];
  columnas = document.getElementById("students").rows[0].cells;
  for (var i = 0; i <columnas.length; i++) {
    colum_names.push(columnas[i].getAttribute("name"));
  }
  console.log(colum_names)
  //Tabla para actualizar
  var table = $('#students').DataTable( {
      keys: true,
      columnDefs: [
          {
              "targets": [0],
              "visible": false,
          }
      ]
  } );
  // Tabla para insertar
  var tableNew = $('#addRowTable').DataTable( {
      keys: true,
      bFilter: false,
      bLengthChange: false,
      bPaginate: false,
      bInfo: false,
      columnDefs: [
          {
              "targets": [0],
              "visible": false,
          }
      ]
  } );

  //Add new row
  var contador = 1;
   $('#addRow').on( 'click', function () {
    //hacer el ajaz aqui, un insert normal y que devuelva como respuesta el id que subió
    //mmm ojo con la pass, buscar como poner una default
      tableNew.row.add([contador,'<input type="textbox">','<input type="textbox">','<input type="textbox">','<input type="textbox">','<input type="textbox">']).draw(false); //ERROR PORQUE DESAPARECE LA COLUMNA PARA HTML
      console.log('contador: ',contador)
      contador += 1;
  } );
  //---------

    var sw = true;
    var input;
    var currCell;
 
    table
        .on( 'key', function ( e, datatable, key, cell, originalEvent ) {
            //events.prepend( '<div>Key press: '+key+' for cell <i>'+cell.data()+'</i></div>' );
            //console.log(key);
            if(key != 13){
              if(sw){
                var value = cell.data();
                if(cell.index().column == colum_names.indexOf("saldo") || cell.index().column == colum_names.indexOf("codigo")){
                  cell.data('<input id="intro" type="number" step="10" min="0.0" name="" value='+value+'>')
                }else{
                  cell.data('<input id="intro" type="text" name="" value='+value+'>')
                }
              
              $("#intro").focus();
              sw = false;
              table.keys.disable();
              }
            }else{
              var pos = parseInt(currCell.selector.rows.substr(4,1))*5 + currCell.index().column + 1;;
              table.cell( ':eq('+pos+')' ).focus();
            }

        } )
        .on( 'key-focus', function ( e, datatable, cell ) {
          currCell = cell;
        } )
        .on( 'key-blur', function ( e, datatable, cell ) {
        } )

      window.onkeyup = function(e) {
     var key = e.keyCode ? e.keyCode : e.which;


     if (key == 13) {
        if(sw == false){
          input = document.getElementById("intro").value;
              currCell.data(input);
              sw = true;
              table.keys.enable();
              // PARTE DE AJAX
              columna = currCell.index().column;
              row = currCell.index().row;
              //indexo = document.getElementById("students").rows[row+1].cells[0].innerText;
              indexo = table.cell(row,0).data();
              inputo = input;
              modified = colum_names[columna];
              console.log('fila:',row, 'columna:',columna, 'index:',indexo)
              $.ajax({
                type: 'GET',
                url: 'update',
                data: ({index:indexo,column:modified,new:inputo}),
                success: function(data){
                  console.log("Sucess")
                  console.log(data[0]['name']);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                  alert("some error");
                }
              });
              // PASAR A SIGUIENTE CELDA
              var pos = parseInt(currCell.selector.rows.substr(4,1))*5 + currCell.index().column + 1;
              table.cell( ':eq('+pos+')' ).focus();
        }
         
     }
  }
} );