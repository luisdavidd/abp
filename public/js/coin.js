var Coin = document.getElementById("coin");
var degrees = 0;
var cont = 0;
var sw = true;
function coinmove(){
	//Coin.style.transitionProperty = "transform";
	if(direction == "left"){
		for(var i = 0; i < 180; i++){
			//Coin.style.transitionDuration = "0.5s";
			setTimeout(mover1, 10*i);
		}
	}else{
		for(var i = 0; i < 180; i++){
			//Coin.style.transitionDuration = "0.5s";
			setTimeout(mover2, 10*i);
		}
	}
	//console.log(cont)
	
}

function mover1(){
	cont += 1;
	Coin.style.webkitTransform = "rotateY(" + (degrees+cont) + "deg)";
	if(cont == 91 || cont == -91){
		imag();
	}else{
		if(cont == 271 || cont == -271){
			imag();
		}else{
			if(cont >= 360 || cont <= -360 ){
				degrees += cont;
				cont = 0;
			}
		}
	}
}

function mover2(){
	cont -= 1;
	Coin.style.webkitTransform = "rotateY(" + (degrees+cont) + "deg)";
	if(cont == 91 || cont == -91){
		imag();
	}else{
		if(cont == 271 || cont == -271){
			imag();
		}else{
			if(cont >= 360 || cont <= -360 ){
				degrees += cont;
				cont = 0;
			}
		}
	}
}

function imag(){
	if(sw == true){
		Coin.style.backgroundImage = "url('/images/USSR-mongolia_Spaceflight_Coin.png')";
		sw = false;
	}else{
		Coin.style.backgroundImage = "url('/images/presidential-dollar-coin-reverse-statue-of-liberty-public-domain.png')";
		sw = true;
	}
}

function verify(cont){

}