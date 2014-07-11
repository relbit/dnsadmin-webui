/**
 * url unit
 */

/**
 * @var baseUrl must be defined in $.ready function
 */
var baseUrl;

window.url = {};

url.out = function(relativeUrl) {
    return baseUrl + relativeUrl;
}