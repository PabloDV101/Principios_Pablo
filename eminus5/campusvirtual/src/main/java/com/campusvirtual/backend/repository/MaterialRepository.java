package com.campusvirtual.backend.repository;

import com.campusvirtual.backend.model.Material;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MaterialRepository extends JpaRepository<Material, String> {}