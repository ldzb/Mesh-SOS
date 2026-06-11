package com.ldzb.backend.repository;

import com.ldzb.backend.entity.SosMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SosMessageRepository extends JpaRepository<SosMessage, Long> {
}
