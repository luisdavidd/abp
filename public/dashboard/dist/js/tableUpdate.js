$(document).ready(function() {
  var colum_names=[]; var id_trans = 1;
  columnas = document.getElementById("students").rows[0].cells;
  for (var i = 0; i <columnas.length; i++) {
    colum_names.push(columnas[i].getAttribute("name"));
  }
  console.log(colum_names)
  //colum_names = ["id",name", "last_name", "email", "saldo", "codigo"];
  //Tabla para actualizar
  var tableHistorics = $('#transactions_table').DataTable( {
    responsive: true        
    } );

  var selected = [];
  var table;
  table = $('#students').DataTable( {
      keys: true,
      columnDefs: [
          {
              "targets": [1],
              "visible": false
          },
          {
            'targets': [0],
            'checkboxes': {
               'selectRow': true
            }
          }
      ],
      select: {
            'style': 'multi'
        }
  } );

var names=[]; var id_names = []; var data2 = [];

$.ajax({
type: 'GET',
url: 'transfer',
success: function(data){
  /*console.log(data)
  res_names = data['names'];
  tabla = data['tabla']; names=[];id_names=[];
  for (j in res_names) {
    names.push(res_names[j]['name']);
    id_names.push(res_names[j]['id']);
    data2.push({id: res_names[j]['id'], text: res_names[j]['name']})
  }
      //Initialize Select2 Elements
    $("#subject").select2({
      allowClear: true,
      data: data2,
      placeholder: "Select a subject"

    }); */

    var subjects = data['classes'];
    var NRCs = data['NRCs'];
    var stdNames = data['students_names'];
    var stdIDs = data['students_ids'];
    var data2 = [];
    for(i = 0; i < subjects.length; i++){
      data2.push({id: i, text: subjects[i]})
    }
    
    //Aqui empieza los select2

     //Initialize Select2 Elements
      $("#subject").select2({
        allowClear: true,
        data: data2,
        placeholder: "Select a subject"
      });
      $("#nrc").select2({
        allowClear: true,
        data: [],
        placeholder: "Select a NRC"
      });
      $("#student").select2({
        data: []
      });

      $("#subject").change(function() {
        table.clear();
        table.draw();
        data_nrc = [];
        i_subj = $("#subject").val();
      console.log('indice materia:',i_subj);
        if (i_subj) {
          for(i = 0; i < i_subj.length; i++){
            for(j = 0; j < NRCs[i_subj[i]].length; j++){
            data_nrc.push({id: j, text: NRCs[i_subj[i]][j]})
            }
          } 
        }
        console.log('NRCs: ',NRCs, data_nrc)
        $("#nrc").html('<option></option>');
        $("#nrc").select2({
          data: data_nrc,
          placeholder: "Select a NRC",
          allowClear: true
        });
    });

    $("#nrc").change(function() {
        data_stds = [];
        i_nrc = $("#nrc").val();
        i_subj = $("#subject").val();
        console.log('indices nrc: ',i_nrc)
        console.log(i_nrc,i_subj)
        table.clear();
        table.draw();
        if (i_nrc && i_subj) {
          for(k = 0; k < i_subj.length; k++){
            for(i = 0; i < i_nrc.length; i++){
              for(j = 0; j < stdNames[i_subj[k]][i_nrc[i]].length; j++){
                if (stdIDs[i_subj[k]][i_nrc[i]][j]) {
                  s = stdNames[i_subj[k]][i_nrc[i]][j]
                  table.row.add(["", stdIDs[i_subj[k]][i_nrc[i]][j], s[0],s[1],s[2],s[3],s[4]]).draw(true);
                  //data_stds.push({id: stdIDs[i_subj[k]][i_nrc[i]][j], text: stdNames[i_subj[k]][i_nrc[i]][j]})
                }
              
              }
            } 
          }
        }
        /*
        table = $('#students').DataTable( {
            keys: true,
            columnDefs: [
                {
                    "targets": [1],
                    "visible": false
                },
                {
                  'targets': [0],
                  'checkboxes': {
                     'selectRow': true
                  }
                }
            ],
            select: {
                  'style': 'multi'
              }
        } );
        */
    });

    //Termina select2


    }
    });

    var sw = true;
    var input;
    var currCell;
 
    table
        .on( 'key', function ( e, datatable, key, cell, originalEvent ) {
            //events.prepend( '<div>Key press: '+key+' for cell <i>'+cell.data()+'</i></div>' );
            //console.log(key);
            if(key != 13 && cell.index().column != 0 && cell.index().column != colum_names.indexOf("saldo")){
              if(sw){
                var value = cell.data();
                if(cell.index().column == colum_names.indexOf("saldo")) {
                  cell.data('<input id="intro" type="number" step="10" min="0.0" name="" value="'+value+'" disable>')  
                }
                else if( cell.index().column == colum_names.indexOf("codigo")){
                  cell.data('<input id="intro" type="number" step="10" min="0.0" name="" value="'+value+'">')
                }else{
                  cell.data('<input id="intro" type="text" name="" value="'+value+'">')
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
          //console.log(table.rows( { selected: true } ).data().toArray()[0][1])
          if(cell.index().column != 0){
            //console.log(cell.index().column)
            table.rows( { selected: true } ).deselect()
          }
          
          currCell = cell;
          row = currCell.index().row;
          id_trans = table.cell(row,1).data();
            //var $this = $(this);
            //var $alias = $this.data('alias');

            tableHistorics.clear();
            tableHistorics.draw();
            $.ajax({
              type: 'GET',
              url: 'userTransactions',
              data: {'id': id_trans},
              success: function(data){
              //console.log('transacciones: ',data)
              for (i in data) {
                  trans = data[i];
                  
                  date = new Date(trans[6]).toString();
                  date = date.split("GMT")[0]
                  tableHistorics.row.add([trans[0]+' '+trans[1],trans[2]+' '+trans[3],trans[4],trans[5],date]).draw(false);
            }}});

            // Pass clicked link element to another function
            //myfunction($this, $alias)


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
              indexo = table.cell(row,1).data();
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


  //empieza transferecia

  $("#transfer").click(function() {
    amount = $("#amount").val();
    observations = $("#observations").val();
    //students_id = id_trans;
    nrc = $("#nrc").select2("data")[0].text;
    selectedRows = table.rows( { selected: true } ).data().toArray();
    var students_id = [];
    for (var i = 0; i < selectedRows.length; i++) {
      students_id.push(selectedRows[i][1]);
    }

    console.log(amount,observations,students_id,nrc)
    var c_error = 0;
    var envio = 0;
    //for(var i=0; i <)
    $.ajax({
        type: 'GET',
        url: 'newTransaction',
        data: {amount:amount, observations:observations, student: students_id, nrc:nrc},
        success: function(){
          window.location='historicalTransactions'
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {

          if (c_error<1) {
            alert("Please check your data");
            c_error += 1;
          }
           
        }
      }); 
    
  });  

    //termina transferencia
} );