// path: backend/src/main/java/com/ldzb/backend/controller/SyncController.java
package com.ldzb.backend.controller;

import com.ldzb.backend.dto.SosMessageRequest;
import com.ldzb.backend.entity.SosMessage;
import com.ldzb.backend.repository.SosMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 릴레이 노드로부터 전달받은 SOS 메시지를 일괄 동기화하는 컨트롤러
 * Bulk insert를 통해 네트워크 오버헤드를 최소화함
 */
@RestController
@RequestMapping("/api/v1/sync")
@RequiredArgsConstructor
public class SyncController {

    private final SosMessageRepository sosMessageRepository;

    @PostMapping("/bulk")
    public String bulkSync(@RequestBody List<SosMessageRequest> requests) {
        List<SosMessage> messages = requests.stream()
                .map(req -> SosMessage.builder()
                        .senderId(req.getSenderId())
                        .latitude(req.getLatitude())
                        .longitude(req.getLongitude())
                        .message(req.getMessage())
                        .timestamp(req.getTimestamp())
                        .build())
                .collect(Collectors.toList());

        sosMessageRepository.saveAll(messages);
        return "Successfully synced " + messages.size() + " messages.";
    }
}
