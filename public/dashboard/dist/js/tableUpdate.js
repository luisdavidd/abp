$(document).ready(function() {
  var colum_names=[];
  columnas = document.getElementById("students").rows[0].cells;
  for (var i = 0; i <columnas.length; i++) {
    colum_names.push(columnas[i].getAttribute("name"));
  }
  console.log(colum_names)
  //colum_names = ["id",name", "last_name", "email", "saldo", "codigo"];
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
  $.ajax({
    type: 'GET',
    url: 'editStudents',
    success: function(data){
      console.log('reload @user: ',data)
      for (i in data) {
        user = data[i];
        console.log('user_id:', user)
        table.row.add([user['id'],user['name'],user['last_name'],user['email'],user['saldo'],user['codigo']]).draw(false);
      }
      
      
    }
  });

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
              var pos = parseInt(currCell.selector.rows.substr(4,1))*5 + currCell.index().column + 1;
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