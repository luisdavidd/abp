function PreviewImage() {
    var oFReader = new FileReader();
    oFReader.readAsDataURL(document.getElementById("user_avatar").files[0]);

    oFReader.onload = function (oFREvent) {
        document.getElementById("user_avatar_Preview").src = oFREvent.target.result;
    };
};