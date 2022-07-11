const handelSubmit = () => {
  let nickname = document.getElementById("nickname").value;
  let username = document.getElementById("username").value;
  let password = document.getElementById("password").value;
  let confirmPassword = document.getElementById("confirm_password").value;

  if (username === "") {
    return;
  }
  if (nickname === "") {
    return;
  }

  if (password === "") {
    return;
  }
  if (confirmPassword === "") {
    return;
  }
  if (!(password === confirmPassword)){
    new bootstrap.Toast(document.querySelector('#messageToast')).show();
    document.getElementById("password").focus()
    return;
  }

  document.getElementById("password").value = "";
  document.getElementById("confirm_password").value = "";


};
