use thiserror::Error;

#[derive(Error, Debug, Clone)]
pub enum Error {
    #[error("Reqwest: {0}")]
    Reqwest(String),
    #[error("tokio join error: {0}")]
    TokioJoinError(String),
}

impl std::convert::From<reqwest::Error> for Error {
    fn from(err: reqwest::Error) -> Self {
        Error::Reqwest(err.to_string())
    }
}

impl std::convert::From<tokio::task::JoinError> for Error {
    fn from(err: tokio::task::JoinError) -> Self {
        Error::TokioJoinError(err.to_string())
    }
}
