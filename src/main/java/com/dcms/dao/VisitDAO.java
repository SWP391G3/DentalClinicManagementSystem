package com.dcms.dao;

import com.dcms.model.Visit;
import com.dcms.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Visits table in SQL Server.
 */
public class VisitDAO {

    private static final Logger LOGGER = Logger.getLogger(VisitDAO.class.getName());

    /**
     * Atomically marks a scheduled appointment Arrived and creates its Visit.
     * Returns the generated VisitId, -1 on a database failure and 0 when the
     * caller should use the legacy DAO flow (kept for mocked/older adapters).
     */
    public int checkInAndCreateVisit(int appointmentId, Visit visit) {
        if (appointmentId <= 0 || visit == null) {
            return -1;
        }
        String updateAppointment = "UPDATE dbo.Appointments SET Status = 'Arrived', UpdatedAt = SYSDATETIME() "
                + "WHERE AppointmentId = ? AND Status IN ('Pending', 'Confirmed')";
        String insertVisit = "INSERT INTO dbo.Visits (PatientId, PrimaryDentistId, AppointmentId, CheckInTime, Status, VisitType, Notes, Operatory, CreatedAt) "
                + "VALUES (?, ?, ?, SYSDATETIME(), ?, ?, ?, ?, SYSDATETIME())";
        Connection conn = null;
        PreparedStatement appointmentPs = null;
        PreparedStatement visitPs = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            appointmentPs = conn.prepareStatement(updateAppointment);
            appointmentPs.setInt(1, appointmentId);
            if (appointmentPs.executeUpdate() != 1) {
                conn.rollback();
                return -1;
            }

            visitPs = conn.prepareStatement(insertVisit, Statement.RETURN_GENERATED_KEYS);
            visitPs.setInt(1, visit.getPatientId());
            visitPs.setInt(2, visit.getPrimaryDentistId());
            visitPs.setInt(3, appointmentId);
            visitPs.setString(4, visit.getStatus());
            visitPs.setString(5, visit.getVisitType());
            visitPs.setString(6, visit.getNotes());
            visitPs.setString(7, visit.getOperatory() != null ? visit.getOperatory() : "Ghế 1 - P.101");
            if (visitPs.executeUpdate() != 1) {
                conn.rollback();
                return -1;
            }
            rs = visitPs.getGeneratedKeys();
            if (!rs.next()) {
                conn.rollback();
                return -1;
            }
            int visitId = rs.getInt(1);
            conn.commit();
            visit.setVisitId(visitId);
            return visitId;
        } catch (SQLException ex) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.WARNING, "Could not rollback check-in transaction", rollbackEx);
                }
            }
            LOGGER.log(Level.SEVERE, "Error atomically checking in appointment: " + appointmentId, ex);
            return -1;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) { }
            }
            DBContext.close(null, visitPs, rs);
            DBContext.close(conn, appointmentPs, null);
        }
    }

    public int create(Visit visit) {
        String sql = "INSERT INTO dbo.Visits (PatientId, PrimaryDentistId, AppointmentId, CheckInTime, Status, VisitType, Notes, Operatory, CreatedAt) " +
                     "VALUES (?, ?, ?, SYSDATETIME(), ?, ?, ?, ?, SYSDATETIME())";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, visit.getPatientId());
            ps.setInt(2, visit.getPrimaryDentistId());

            if (visit.getAppointmentId() != null && visit.getAppointmentId() > 0) {
                ps.setInt(3, visit.getAppointmentId());
            } else {
                ps.setNull(3, Types.INTEGER); // NULL for Walk-in or Emergency
            }

            ps.setString(4, visit.getStatus());
            ps.setString(5, visit.getVisitType());
            ps.setString(6, visit.getNotes());
            ps.setString(7, visit.getOperatory() != null ? visit.getOperatory() : "Ghế 1 - P.101");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int id = rs.getInt(1);
                    visit.setVisitId(id);
                    return id;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating visit for patient: " + visit.getPatientId(), ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return -1;
    }

    public Visit getVisitById(int visitId) {
        return findById(visitId);
    }

    public Visit findById(int visitId) {
        String sql = "SELECT v.VisitId, v.PatientId, v.PrimaryDentistId, v.AppointmentId, v.CheckInTime, v.CheckOutTime, " +
                     "v.Status, v.VisitType, v.Notes, v.Operatory, v.CreatedAt, v.UpdatedAt, " +
                     "p.FullName AS PatientName, p.Phone AS PatientPhone, p.MedicalAlerts, p.Allergies, " +
                     "du.FullName AS DentistName " +
                     "FROM dbo.Visits v " +
                     "JOIN dbo.Patients p ON v.PatientId = p.PatientId " +
                     "JOIN dbo.Dentists d ON v.PrimaryDentistId = d.DentistId " +
                     "JOIN dbo.Users du ON d.DentistId = du.UserId " +
                     "WHERE v.VisitId = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, visitId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToVisit(rs);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in findById for visitId: " + visitId, ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    public Visit findByAppointmentId(int appointmentId) {
        String sql = "SELECT v.VisitId, v.PatientId, v.PrimaryDentistId, v.AppointmentId, v.CheckInTime, v.CheckOutTime, " +
                     "v.Status, v.VisitType, v.Notes, v.Operatory, v.CreatedAt, v.UpdatedAt, " +
                     "p.FullName AS PatientName, p.Phone AS PatientPhone, p.MedicalAlerts, p.Allergies, " +
                     "du.FullName AS DentistName " +
                     "FROM dbo.Visits v " +
                     "JOIN dbo.Patients p ON v.PatientId = p.PatientId " +
                     "JOIN dbo.Dentists d ON v.PrimaryDentistId = d.DentistId " +
                     "JOIN dbo.Users du ON d.DentistId = du.UserId " +
                     "WHERE v.AppointmentId = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, appointmentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToVisit(rs);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in findByAppointmentId: " + appointmentId, ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return null;
    }

    public List<Visit> findWaitingVisits() {
        return getWaitingQueue(null);
    }

    public List<Visit> findVisitsByDentistAndDate(int dentistId, java.time.LocalDate date) {
        List<Visit> list = new ArrayList<>();
        String sql = "SELECT v.VisitId, v.PatientId, v.PrimaryDentistId, v.AppointmentId, v.CheckInTime, v.CheckOutTime, " +
                     "v.Status, v.VisitType, v.Notes, v.Operatory, v.CreatedAt, v.UpdatedAt, " +
                     "p.FullName AS PatientName, p.Phone AS PatientPhone, p.MedicalAlerts, p.Allergies, " +
                     "du.FullName AS DentistName " +
                     "FROM dbo.Visits v " +
                     "JOIN dbo.Patients p ON v.PatientId = p.PatientId " +
                     "JOIN dbo.Dentists d ON v.PrimaryDentistId = d.DentistId " +
                     "JOIN dbo.Users du ON d.DentistId = du.UserId " +
                     "WHERE v.PrimaryDentistId = ? AND CAST(v.CheckInTime AS DATE) = ? " +
                     "ORDER BY v.CheckInTime ASC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, dentistId);
            ps.setDate(2, java.sql.Date.valueOf(date));
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToVisit(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in findVisitsByDentistAndDate", ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public List<Visit> getWaitingQueue(Integer dentistId) {
        List<Visit> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT v.VisitId, v.PatientId, v.PrimaryDentistId, v.AppointmentId, v.CheckInTime, v.CheckOutTime, " +
            "v.Status, v.VisitType, v.Notes, v.Operatory, v.CreatedAt, v.UpdatedAt, " +
            "p.FullName AS PatientName, p.Phone AS PatientPhone, p.MedicalAlerts, p.Allergies, " +
            "du.FullName AS DentistName " +
            "FROM dbo.Visits v " +
            "JOIN dbo.Patients p ON v.PatientId = p.PatientId " +
            "JOIN dbo.Dentists d ON v.PrimaryDentistId = d.DentistId " +
            "JOIN dbo.Users du ON d.DentistId = du.UserId " +
            "WHERE v.Status = 'Waiting' AND CAST(v.CheckInTime AS DATE) = CAST(SYSDATETIME() AS DATE) "
        );

        if (dentistId != null && dentistId > 0) {
            sql.append("AND v.PrimaryDentistId = ? ");
        }
        sql.append("ORDER BY v.CheckInTime ASC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            if (dentistId != null && dentistId > 0) {
                ps.setInt(1, dentistId);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToVisit(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching waiting queue", ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public boolean updateStatus(int visitId, String status) {
        String sql;
        if (Visit.STATUS_COMPLETED.equalsIgnoreCase(status)) {
            sql = "UPDATE dbo.Visits SET Status = ?, CheckOutTime = SYSDATETIME(), UpdatedAt = SYSDATETIME() WHERE VisitId = ?";
        } else {
            sql = "UPDATE dbo.Visits SET Status = ?, UpdatedAt = SYSDATETIME() WHERE VisitId = ?";
        }

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, visitId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating visit status for visitId: " + visitId, ex);
        } finally {
            DBContext.close(conn, ps, null);
        }
        return false;
    }

    public boolean updateOperatory(int visitId, String operatory) {
        String sql = "UPDATE dbo.Visits SET Operatory = ?, UpdatedAt = SYSDATETIME() WHERE VisitId = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, operatory);
            ps.setInt(2, visitId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating visit operatory for visitId: " + visitId, ex);
        } finally {
            DBContext.close(conn, ps, null);
        }
        return false;
    }

    public List<Visit> findVisitsByPatientId(int patientId) {
        List<Visit> list = new ArrayList<>();
        String sql = "SELECT v.VisitId, v.PatientId, v.PrimaryDentistId, v.AppointmentId, v.CheckInTime, v.CheckOutTime, " +
                     "v.Status, v.VisitType, v.Notes, v.Operatory, v.CreatedAt, v.UpdatedAt, " +
                     "p.FullName AS PatientName, p.Phone AS PatientPhone, p.MedicalAlerts, p.Allergies, " +
                     "du.FullName AS DentistName " +
                     "FROM dbo.Visits v " +
                     "JOIN dbo.Patients p ON v.PatientId = p.PatientId " +
                     "JOIN dbo.Dentists d ON v.PrimaryDentistId = d.DentistId " +
                     "JOIN dbo.Users du ON d.DentistId = du.UserId " +
                     "WHERE v.PatientId = ? " +
                     "ORDER BY v.CheckInTime DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, patientId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToVisit(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in findVisitsByPatientId for patientId: " + patientId, ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    public List<Visit> findTodayVisits() {
        List<Visit> list = new ArrayList<>();
        String sql = "SELECT v.VisitId, v.PatientId, v.PrimaryDentistId, v.AppointmentId, v.CheckInTime, v.CheckOutTime, " +
                     "v.Status, v.VisitType, v.Notes, v.Operatory, v.CreatedAt, v.UpdatedAt, " +
                     "p.FullName AS PatientName, p.Phone AS PatientPhone, p.MedicalAlerts, p.Allergies, " +
                     "du.FullName AS DentistName " +
                     "FROM dbo.Visits v " +
                     "JOIN dbo.Patients p ON v.PatientId = p.PatientId " +
                     "JOIN dbo.Dentists d ON v.PrimaryDentistId = d.DentistId " +
                     "JOIN dbo.Users du ON d.DentistId = du.UserId " +
                     "WHERE CAST(v.CheckInTime AS DATE) = CAST(SYSDATETIME() AS DATE) " +
                     "ORDER BY CASE WHEN v.Status = 'Waiting' THEN 1 WHEN v.Status = 'InProgress' THEN 2 ELSE 3 END, v.CheckInTime DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToVisit(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in findTodayVisits", ex);
        } finally {
            DBContext.close(conn, ps, rs);
        }
        return list;
    }

    private Visit mapResultSetToVisit(ResultSet rs) throws SQLException {
        Visit v = new Visit();
        v.setVisitId(rs.getInt("VisitId"));
        v.setPatientId(rs.getInt("PatientId"));
        v.setPrimaryDentistId(rs.getInt("PrimaryDentistId"));

        int apptId = rs.getInt("AppointmentId");
        if (!rs.wasNull()) {
            v.setAppointmentId(apptId);
        } else {
            v.setAppointmentId(null);
        }

        Timestamp inTs = rs.getTimestamp("CheckInTime");
        if (inTs != null) v.setCheckInTime(inTs.toLocalDateTime());

        Timestamp outTs = rs.getTimestamp("CheckOutTime");
        if (outTs != null) v.setCheckOutTime(outTs.toLocalDateTime());

        v.setStatus(rs.getString("Status"));
        v.setVisitType(rs.getString("VisitType"));
        v.setNotes(rs.getString("Notes"));

        try {
            v.setOperatory(rs.getString("Operatory"));
        } catch (SQLException ignored) {
        }

        v.setPatientName(rs.getString("PatientName"));
        v.setPatientPhone(rs.getString("PatientPhone"));
        v.setMedicalAlerts(rs.getString("MedicalAlerts"));
        v.setAllergies(rs.getString("Allergies"));
        v.setDentistName(rs.getString("DentistName"));

        Timestamp createdTs = rs.getTimestamp("CreatedAt");
        if (createdTs != null) v.setCreatedAt(createdTs.toLocalDateTime());
        Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
        if (updatedTs != null) v.setUpdatedAt(updatedTs.toLocalDateTime());

        return v;
    }
}
