/**
 * Set random color on material.
 */
AFRAME.registerComponent("random-color", {
  dependencies: ["material"],

  init: function() {
    this.el.setAttribute("material", "color", getRandomColor());
  }
});

function getRandomColor() {

  var color = "#000000";

  /*color += letters[Math.round(Math.random() * 0.5)];*/

  return color;
}
