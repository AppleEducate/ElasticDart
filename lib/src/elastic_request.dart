part of elastic_dart;

class ElasticRequest {
  final String host;

  ElasticRequest(this.host);

  Future get(String path) => _request('GET', path);
  Future post(String path, body) => _request('POST', path, body);
  Future put(String path, body) => _request('PUT', path, body);
  Future delete(String path) => _request('DELETE', path);

  Future _request(String method, String path, [body]) async {
    var request = new http.Request(method, Uri.parse('$host/$path'));
    if (body != null) {
      if (body is! String) {
        body = JSON.encode(body);
      }
      request.body = body;
    }

    var response = await request.send();
    var responseBody = _responseDecoder.convert(await response.stream.toBytes());

    if (response.statusCode >= 400) {
      if (responseBody['error'].startsWith('IndexMissingException')) {
        throw new IndexMissingException(responseBody);
      }
      throw new ElasticSearchException(responseBody);
    }

    return responseBody;
  }
}