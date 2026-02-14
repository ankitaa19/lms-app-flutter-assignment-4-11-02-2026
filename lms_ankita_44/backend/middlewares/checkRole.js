const checkLibrarian = (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        message: 'Authentication required',
      });
    }

    if (req.user.userType !== 'LIBRARIAN') {
      return res.status(403).json({
        message: 'Access denied. Librarian privileges required.',
      });
    }

    next();
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

const checkStudent = (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        message: 'Authentication required',
      });
    }

    if (req.user.userType !== 'STUDENT') {
      return res.status(403).json({
        message: 'Access denied. Student privileges required.',
      });
    }

    next();
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

module.exports = { checkLibrarian, checkStudent };
