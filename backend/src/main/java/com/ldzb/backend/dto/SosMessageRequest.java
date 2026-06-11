package com.ldzb.backend.dto;

import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Getter
@Setter
public class SosMessageRequest {
    private String senderId;
    private Double latitude;
    private Double longitude;
    private String message;
    private LocalDateTime timestamp;
}
