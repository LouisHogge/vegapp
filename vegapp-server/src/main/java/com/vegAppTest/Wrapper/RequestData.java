package com.vegAppTest.Wrapper;

import com.fasterxml.jackson.databind.JsonNode;

import lombok.Data;

@Data

public class RequestData {
  public Long api_number;
  public String url;
  public JsonNode body;
  public String request_type;

  RequestData() {

  }

}
