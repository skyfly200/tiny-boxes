<template>
  <div class="hello">
    <h1>{{ message }}</h1>
  </div>
</template>

<script>
export default {
  name: '<%= name.pascalCase %>',
  data() {
    return {
      message: 'Hello World!'
    }
  }
}
</script>

<% if (scoped) { %>
<style scoped>
<% } else { %>
<style>
<% } %>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
