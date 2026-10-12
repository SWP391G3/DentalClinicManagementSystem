package com.dcms.dao;

import com.dcms.model.PreTreatmentAssessment;
import com.dcms.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for PreTreatmentAssessments table.
 */
public class PreTreatmentAssessmentDAO {
    private static final Logger LOGGER = Logger.getLogger(PreTreatmentAssessmentDAO.class.getName());

    public int createOrUpdate(PreTreatmentAssessment a) {
        PreTreatmentAssessment existing = findByVisitId(a.getVisitId());
        if (existing != null) {
            update(a);
            return existing.getAssessmentId();
        }

        String sql = "INSERT INTO dbo.PreTreatmentAssessments (VisitId, PatientId, BloodPressure, PulseRate, BloodSugar, BleedingRisk, AnxietyLevel, MedicalClearance, Notes, RecordedAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, a.getVisitId());
            ps.setInt(2, a.getPatientId());
            ps.setString(3, a.getBloodPressure());

            if (a.getPulseRate() != null) {
                ps.setInt(4, a.getPulseRate());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }

            if (a.getBloodSugar() != null) {
                ps.setBigDecimal(5, a.getBloodSugar());
            } else {
                ps.setNull(5, java.sql.Types.DECIMAL);
            }

            ps.setString(6, a.getBleedingRisk());
            ps.setString(7, a.getAnxietyLevel());
            ps.setBoolean(8, a.isMedicalClearance());
            ps.setString(9, a.getNotes());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int id = rs.getInt(1);
                    a.setAssessmentId(id);
                    return id;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating assessment for visit: " + a.getVisitId(), ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return -1;
    }

    public boolean update(PreTreatmentAssessment a) {
        String sql = "UPDATE dbo.PreTreatmentAssessments SET BloodPressure = ?, PulseRate = ?, BloodSugar = ?, " +
                     "BleedingRisk = ?, AnxietyLevel = ?, MedicalClearance = ?, Notes = ?, RecordedAt = SYSDATETIME() " +
                     "WHERE VisitId = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, a.getBloodPressure());
            if (a.getPulseRate() != null) {
                ps.setInt(2, a.getPulseRate());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            if (a.getBloodSugar() != null) {
                ps.setBigDecimal(3, a.getBloodSugar());
            } else {
                ps.setNull(3, java.sql.Types.DECIMAL);
            }
            ps.setString(4, a.getBleedingRisk());
            ps.setString(5, a.getAnxietyLevel());
            ps.setBoolean(6, a.isMedicalClearance());
            ps.setString(7, a.getNotes());
            ps.setInt(8, a.getVisitId());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating assessment for visit: " + a.getVisitId(), ex);
        } finally {
            DBContext.close(conn, ps, null);
        }
        return false;
    }

    public PreTreatmentAssessment findByVisitId(int visitId) {
        String sql = "SELECT AssessmentId, VisitId, PatientId, BloodPressure, PulseRate, BloodSugar, BleedingRisk, " +
                     "AnxietyLevel, MedicalClearance, Notes, RecordedAt " +
                     "FROM dbo.PreTreatmentAssessments WHERE VisitId = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, visitId);
            rs = ps.executeQuery();
            if (rs.next()) {
                PreTreatmentAssessment a = new PreTreatmentAssessment();
                a.setAssessmentId(rs.getInt("AssessmentId"));
                a.setVisitId(rs.getInt("VisitId"));
                a.setPatientId(rs.getInt("PatientId"));
                a.setBloodPressure(rs.getString("BloodPressure"));

                int pulse = rs.getInt("PulseRate");
                if (!rs.wasNull()) a.setPulseRate(pulse);

                a.setBloodSugar(rs.getBigDecimal("BloodSugar"));
                a.setBleedingRisk(rs.getString("BleedingRisk"));
                a.setAnxietyLevel(rs.getString("AnxietyLevel"));
                a.setMedicalClearance(rs.getBoolean("MedicalClearance"));
                a.setNotes(rs.getString("Notes"));

                Timestamp ts = rs.getTimestamp("RecordedAt");
                if (ts != null) a.setRecordedAt(ts.toLocalDateTime());
                return a;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error findByVisitId in PreTreatmentAssessmentDAO: " + visitId, ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    public java.util.Map<Integer, PreTreatmentAssessment> findAssessmentsForVisits(List<Integer> visitIds) {
        java.util.Map<Integer, PreTreatmentAssessment> map = new java.util.HashMap<>();
        if (visitIds == null || visitIds.isEmpty()) {
            return map;
        }
        StringBuilder sql = new StringBuilder(
            "SELECT AssessmentId, VisitId, PatientId, BloodPressure, PulseRate, BloodSugar, BleedingRisk, " +
            "AnxietyLevel, MedicalClearance, Notes, RecordedAt " +
            "FROM dbo.PreTreatmentAssessments WHERE VisitId IN ("
        );
        for (int i = 0; i < visitIds.size(); i++) {
            sql.append(i == 0 ? "?" : ", ?");
        }
        sql.append(")");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < visitIds.size(); i++) {
                ps.setInt(i + 1, visitIds.get(i));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                PreTreatmentAssessment a = new PreTreatmentAssessment();
                a.setAssessmentId(rs.getInt("AssessmentId"));
                a.setVisitId(rs.getInt("VisitId"));
                a.setPatientId(rs.getInt("PatientId"));
                a.setBloodPressure(rs.getString("BloodPressure"));
                int pulse = rs.getInt("PulseRate");
                if (!rs.wasNull()) a.setPulseRate(pulse);
                a.setBloodSugar(rs.getBigDecimal("BloodSugar"));
                a.setBleedingRisk(rs.getString("BleedingRisk"));
                a.setAnxietyLevel(rs.getString("AnxietyLevel"));
                a.setMedicalClearance(rs.getBoolean("MedicalClearance"));
                a.setNotes(rs.getString("Notes"));
                Timestamp ts = rs.getTimestamp("RecordedAt");
                if (ts != null) a.setRecordedAt(ts.toLocalDateTime());
                map.put(a.getVisitId(), a);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in findAssessmentsForVisits", ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return map;
    }
}
